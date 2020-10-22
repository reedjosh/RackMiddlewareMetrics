#[macro_use]
extern crate helix;
extern crate md5;

ruby! {
    class MRubyExt {
        def compute(body: String) {
	    let digest = md5::compute(body);
 	    println!("{:?}", digest);
        }
    }
}

