extern crate md5;


fn main() {
	let digest = md5::compute(b"abcdefghijklmnopqrstuvwxyz");
 	println!("{:?}", digest)
}
