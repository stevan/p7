
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::io::stream ];

use org::p7::core::util qw[ Logger ];

class IO::Stream::Source::LinesFromHandle :isa(Stream::Source) {
    field $fh :param :reader;

    method next { LOG $self if DEBUG; scalar $fh->getline }

    method has_next { LOG $self if DEBUG; !$fh->eof }
}
