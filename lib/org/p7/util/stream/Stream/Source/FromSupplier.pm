
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

class Stream::Source::FromSupplier :isa(Stream::Source) {
    field $supplier :param :reader;

    method next { $supplier->get }
    method has_next { true }
}
