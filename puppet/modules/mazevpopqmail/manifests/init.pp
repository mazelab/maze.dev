# 
# requires maze core module
#
class mazevpopqmail(
    $vpopmail_homedir      = params_lookup( 'vpopmail_homedir' )
) inherits mazevpopqmail::params {
    
    if($fqdn) {
        include mazevpopqmail::install
        include mazevpopqmail::scripts
    } else {
        notify{'No FQDN configured... skiped further actions':}
    }
    
}

