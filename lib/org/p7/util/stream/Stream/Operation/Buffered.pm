
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::Buffered :isa(Stream::Operation::Node) {
    field $source :param;

    field @buffer    :reader;
    field $buffering :reader = false;

    field @replay;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source } if DEBUG;
    }

    method start_buffering { LOG $self if DEBUG; $buffering = true  }
    method stop_buffering  { LOG $self if DEBUG; $buffering = false }

    method clear_buffer { LOG $self if DEBUG; @buffer = () }
    method flush_buffer {
        LOG $self if DEBUG;
        my @temp = @buffer;
        $self->clear_buffer;
        return @temp;
    }

    method rewind { LOG $self if DEBUG; @replay = $self->flush_buffer }

    method next {
        LOG $self if DEBUG;
        return shift @replay if @replay;

        my $val = $source->next;
        push @buffer => $val if $buffering;
        return $val;
    }

    method has_next {
        LOG $self if DEBUG;
        @replay || $source->has_next
    }
}
