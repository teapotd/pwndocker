use std::fs;

use anyhow::{Result, anyhow, bail};
use clap::Parser as _;
use gimli::write::{
    Address, Attribute, AttributeValue, DebuggingInformationEntry, Dwarf, EndianVec, LineProgram,
    Sections, Unit, UnitEntryId, Writer as _,
};
use object::{Object as _, ObjectSection as _};

/// Extract type debug info from object files.
#[derive(clap::Parser, Debug)]
#[command()]
struct Args {
    /// Input file.
    #[arg()]
    input: String,

    /// Output file.
    #[arg()]
    output: String,
}

fn main() -> Result<()> {
    let args = Args::parse();
    let input_data = fs::read(args.input)?;
    let output_file = fs::File::create(args.output)?;
    let mut dwarf = parse_dwarf(&object::File::parse(&*input_data)?)?;
    process_dwarf(&mut dwarf)?;
    serialize_dwarf(&mut dwarf)?
        .write_stream(output_file)
        .map_err(|_| anyhow!("Error writing object file"))?;
    Ok(())
}

fn parse_dwarf(obj: &object::File) -> Result<Dwarf> {
    let endian = match obj.endianness() {
        object::Endianness::Little => gimli::RunTimeEndian::Little,
        object::Endianness::Big => gimli::RunTimeEndian::Big,
    };

    let sections = gimli::read::DwarfSections::load(|id| -> Result<_> {
        Ok(match obj.section_by_name(id.name()) {
            Some(section) => section.uncompressed_data()?,
            None => Default::default(),
        })
    })?;

    let dwarf = sections.borrow(|section| gimli::read::EndianSlice::new(&section, endian));

    // We don't care about relocations as we will strip all addresses anyway.
    Ok(Dwarf::from(&dwarf, &|addr| Some(Address::Constant(addr)))?)
}

fn serialize_dwarf(dwarf: &mut Dwarf) -> Result<object::write::Object> {
    let mut obj = object::write::Object::new(
        object::BinaryFormat::Elf,
        object::Architecture::X86_64,
        object::Endianness::Little,
    );

    let mut sections = Sections::new(EndianVec::new(gimli::LittleEndian));
    dwarf.write(&mut sections)?;

    sections.for_each_mut(|id, section| -> Result<()> {
        if section.len() == 0 {
            return Ok(());
        }

        let kind = if id.is_string() {
            object::SectionKind::DebugString
        } else {
            object::SectionKind::Debug
        };

        let section_id = obj.add_section(Vec::new(), id.name().into(), kind);
        obj.set_section_data(section_id, section.take(), 1);
        Ok(())
    })?;

    Ok(obj)
}

fn process_dwarf(dwarf: &mut Dwarf) -> Result<()> {
    for (_, unit) in dwarf.units.iter_mut() {
        if !process_subtree(unit, unit.root()) {
            bail!("Cannot delete root");
        }
        unit.line_program = LineProgram::none();
        unit.ranges = Default::default();
    }
    dwarf.line_programs = Default::default();
    dwarf.line_strings = Default::default();
    Ok(())
}

fn process_subtree(unit: &mut Unit, id: UnitEntryId) -> bool {
    let entry = unit.get_mut(id);
    if !process_entry(entry) {
        return false;
    }

    let to_delete: Vec<_> = entry
        .attrs()
        .filter(|e| !should_keep_attribute(*e))
        .map(|e| e.name())
        .collect();

    for name in to_delete {
        entry.delete(name);
    }

    let children: Vec<_> = entry.children().copied().collect();
    for child in children {
        if !process_subtree(unit, child) {
            unit.get_mut(id).delete_child(child);
        }
    }
    true
}

fn process_entry(entry: &mut DebuggingInformationEntry) -> bool {
    match entry.tag() {
        gimli::DW_TAG_call_site
        | gimli::DW_TAG_call_site_parameter
        | gimli::DW_TAG_dwarf_procedure
        | gimli::DW_TAG_label
        | gimli::DW_TAG_GNU_call_site
        | gimli::DW_TAG_GNU_call_site_parameter
        | gimli::DW_TAG_inlined_subroutine => {
            return false;
        }
        gimli::DW_TAG_variable => {
            entry.set(gimli::DW_AT_external, AttributeValue::Flag(true));
        }
        _ => {}
    }
    true
}

fn should_keep_attribute(attr: &Attribute) -> bool {
    use AttributeValue::*;
    match attr.get() {
        Address(_) | Exprloc(_) | DebugInfoRefSup(_) | LineProgramRef | LocationListRef(_)
        | DebugMacinfoRef(_) | DebugMacroRef(_) | RangeListRef(_) | DebugStrRefSup(_)
        | LineStringRef(_) | FileIndex(_) => false,
        _ => true,
    }
}
