
use v5.40;
use experimental qw[ class ];

class Exception {
    use overload '""' => 'to_string';

    field $msg :param :reader;

    field @stack :reader;

    sub throw ($class, $msg, %args) { die $class->new( msg => $msg, %args ) }

    ADJUST {
        my $x = 1;
        my @raw;
        while ( my @c = (caller( $x++ ))[0 .. 3] ) {
            push @raw => \@c;
        }

        foreach my ($i, $raw) (indexed @raw) {
            my ($package, $filename, $line, $subroutine) = @$raw;
            push @stack => Exception::StackFrame->new(
                package    => $package,
                filename   => $filename,
                line       => $line,
                subroutine => $subroutine,
                caller     => $raw[ $i+1 ] ? $raw[ $i+1 ]->[-1] : undef,
            );
        }
    }

    my sub format_stack_trace ($indent, @trace) {
        return '' unless @trace;
        my @out;
        foreach my $i (0 .. $#trace) {
            if ($i < $#trace) {
                push @out => sprintf '%s├─ %s' => $indent, $trace[$i]->to_string;
            }
            else {
                push @out => sprintf '%s└─ %s' => $indent, $trace[$i]->to_string;
            }
        }
        return join "\n" => "Trace:", @out, '';
    }

    method to_string {
        state $indent = '  ';
        my ($top, @trace) = @stack;
        sprintf "Error: %s\n${indent}in %s() at %s:%d\n%s" =>
            $msg,
            $top->caller // 'eval',
            $top->filename,
            $top->line,
            format_stack_trace($indent, @trace)
        ;
    }
}

class Exception::StackFrame {
    use overload '""' => 'to_string';

    field $package    :param :reader;
    field $filename   :param :reader;
    field $line       :param :reader;
    field $subroutine :param :reader;
    field $caller     :param :reader;

    method to_string {
        sprintf '%s() called at %s:%d' =>
            map { $_ // '~' }
                $subroutine, $filename, $line;
    }
}

# Exception->throw("Hi");
# sub foo   () { Exception->throw("Hello") }
# sub bar   () { foo() }
# sub baz   () { bar() }
# sub gorch () { baz() }
# gorch();


