use pyo3::prelude::*;

mod load;
use load::load_module;

use std::ffi::{c_char, c_int, CString};

fn to_raw_args(args: Vec<String>) -> Vec<*mut c_char> {
    let mut raw_args: Vec<_> = args
        .into_iter()
        .map(|x| CString::new(x).unwrap().into_raw())
        .collect();
    raw_args.push(std::ptr::null_mut());
    raw_args
}

pub fn py_main(args: Vec<String>) -> i32 {
    let mut argv = to_raw_args(args);
    let argc = (argv.len() - 1) as c_int;
    unsafe { pyo3::ffi::Py_BytesMain(argc, argv.as_mut_ptr()) }
}

pub fn main() -> PyResult<()> {
    pyo3::append_to_inittab!(load_module);

    py_main(std::env::args().collect());

    Ok(())
}