# = Class: vpopqmail
#
# This is the main vpopqmail class
#
# == Parameters
#
# Default class params - As defined in vpopqmail::params.
#
# [*vpopmail_homedir*]
#   vpopqmail homedir where domains, emails, etc are stored
#
# == Author
#   CDS-Internetagentur
#
class vpopqmail(
    $vpopmail_homedir      = params_lookup( 'vpopmail_homedir' )
) inherits vpopqmail::params {

    if($fqdn) {
        include vpopqmail::qmail::init
    } else {
        notify{'No FQDN configured... skiped vpopqmail actions':}
    }

}

