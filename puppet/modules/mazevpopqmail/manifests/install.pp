#
# requires class qmail & vpopqmail
#
class mazevpopqmail::install inherits mazevpopqmail{
 #   class { 'qmail':
 #   }

    include mazevpopqmail::qmail::init


#    class { 'vpopqmail':
#    }

}