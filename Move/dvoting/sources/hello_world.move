 module hello::hello_world {

    public entry fun hello_world() {
        let vect: vector<u8> = b"Hello World";
        let str: std::string::String = std::string::utf8(vect);

        std::debug::print(&str);  // [debug] "Hello World"
    }
}