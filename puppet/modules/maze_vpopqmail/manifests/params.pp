# Class: maze_vpopqmail::params
#
# This class defines default parameters used by the main module class maze_vpopqmail
#
# == Variables
#
# Refer to maze_vpopqmail class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class maze_vpopqmail::params inherits maze {
    $vpopmail_homedir = '/home/vpopmail'
    $vpopmail_user = 'vpopmail'
    $vpopmail_group = 'vchkpw'
}

