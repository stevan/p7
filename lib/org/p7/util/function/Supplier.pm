
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::function ];

class Supplier {
    field $f :param :reader;

    method get { return $f->(); }
}
