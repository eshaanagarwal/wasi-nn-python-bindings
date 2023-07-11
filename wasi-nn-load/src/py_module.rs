use image;
use wasi_nn;
use std::fs::File;
use std::io::Read;

// This function will contain wasi_nn load function which will me mapped to be used with pyo3
#[pyo3::pyfunction]
pub fn load_image_graph(image_tensor: GraphBuilderArray<'_>){
    // Load the model.
    let encoding = wasi_nn::GRAPH_ENCODING_PYTORCH;
    let target = wasi_nn::EXECUTION_TARGET_CPU;
    let graph = wasi_nn::load(&image_tensor, encoding, target);
    return graph;
}


#[pyo3::pyfunction]
pub fn image_to_tensor(path: String, height: u32, width: u32) -> Vec<u8> {
    let mut file_img = File::open(path).unwrap();
    let mut img_buf = Vec::new();
    file_img.read_to_end(&mut img_buf).unwrap();
    let img = image::load_from_memory(&img_buf).unwrap().to_rgb8();
    let resized =
        image::imageops::resize(&img, height, width, ::image::imageops::FilterType::Triangle);
    let mut flat_img: Vec<f32> = Vec::new();
    for rgb in resized.pixels() {
        flat_img.push((rgb[0] as f32 / 255. - 0.485) / 0.229);
        flat_img.push((rgb[1] as f32 / 255. - 0.456) / 0.224);
        flat_img.push((rgb[2] as f32 / 255. - 0.406) / 0.225);
    }
    let bytes_required = flat_img.len() * 4;
    let mut u8_f32_arr: Vec<u8> = vec![0; bytes_required];

    for c in 0..3 {
        for i in 0..(flat_img.len() / 3) {
            // Read the number as a f32 and break it into u8 bytes
            let u8_f32: f32 = flat_img[i * 3 + c] as f32;
            let u8_bytes = u8_f32.to_ne_bytes();

            for j in 0..4 {
                u8_f32_arr[((flat_img.len() / 3 * c + i) * 4) + j] = u8_bytes[j];
            }
        }
    }
    return u8_f32_arr;
}

use pyo3::prelude::*;

use pyo3::{
    types::{PyModule},
    PyResult, Python,
};

#[pyo3::pymodule]
#[pyo3(name = "load")]
pub fn load_module(_py: Python<'_>, module: &PyModule) -> PyResult<()> {
    module.add_function(wrap_pyfunction!(image_to_tensor, module)?)
    module.add_function(wrap_pyfunction!(load, module)?)
}