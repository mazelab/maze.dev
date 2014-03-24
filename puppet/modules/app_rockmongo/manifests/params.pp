# Class: app_rockmongo::params
#
# This class defines default parameters used by the main module class app_rockmongo
#
# == Variables
#
# Refer to app_rockmongo class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class app_rockmongo::params
{
    $repository = 'https://github.com/iwind/rockmongo.git'

    $owner = 'vagrant'
    $group = 'vagrant'
}