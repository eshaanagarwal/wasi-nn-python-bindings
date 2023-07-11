use image;
use wasi_nn;
use std::fs::File;
use std::io::Read;

// This function will contain wasi_nn load function which will me mapped to be used with pyo3
#[pyo3::pyfunction]


use pyo3::prelude::*;

use pyo3::{
    types::{PyModule},
    PyResult, Python,
};

#[pyo3::pymodule]
#[pyo3(name = "load")]
pub fn load_module(_py: Python<'_>, module: &PyModule) -> PyResult<()> {
    module.add_function(wrap_pyfunction!(image_to_tensor, module)?)
}