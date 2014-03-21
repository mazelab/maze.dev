class mazemongodb() inherits mazemongodb::params {
    include mazemongodb::scripts

    class{ "mongodb":
    }
}
