#[macro_use]
extern crate helix;
extern crate md5;

ruby! {
    class MRubyExt {
        def compute(body: String) -> String {
	    let digest = md5::compute(body);
            let ret = format!("{:x}", digest);
 	    return ret;
        }
    }
}

