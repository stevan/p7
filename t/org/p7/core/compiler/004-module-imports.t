
use v5.40;
use experimental qw[ class ];

use lib 't/lib';

use Test::More;
use Test::Differences;

use Data::Dumper;

use org::p7::core::util qw[ Logging ];

use org::p7::core::compiler qw[
    Decompiler
    Decompiler::Match::Builder
];

sub print_ops (@ops) { print_op($_) foreach @ops }
sub print_op  ($op)  { say stringify_op($op)     }

sub stringify_op ($op) {
    sprintf '%15s:%04d │ %s%s' =>
            $op->statement->file,
            $op->statement->line,
            ('  ' x $op->depth),
            $op;
}

package Foo::Bar {
    sub foobar {
        require Foo;
        Foo->VERSION(0.01);
        Foo->import(qw[ bar baz ]);
    }
}

class ModuleImport {
    use overload '""' => 'to_string';

    field $filename :param :reader;
    field $version  :param :reader = undef;
    field $imports  :param :reader = undef;

    method to_string {
        sprintf 'File: %s : %s (%s)' =>
            $filename,
            $version // '~',
            (join ', ' => @$imports)
    }
}

class Deparser::ModuleImport {
    field $stream :param :reader;

    field $result :reader;
    field $error  :reader;

    field $buffer :reader;

    ADJUST {
        $stream = $stream->buffered;
        $buffer = $stream->source;

        $stream = $stream->peek(sub ($op) { INFO ">>>> Parsing: $op" }) if DEBUG;
    }

    method set_result ($r) { $result = $r }
    method set_error  ($e) { $error  = $e }

    field $require;
    field $method_call;

    ADJUST {
        $require = Decompiler::Match::Builder->new
            ->starts_with( name => 'leavesub'  )
            ->followed_by( name => 'lineseq'   )
            ->followed_by( name => 'nextstate' )
            ->followed_by( name => 'require'   )
            ->matches_on( name  => 'const',
                on_match => sub ($op) { $op->op->sv->PV }
            )->build;

        $method_call = Decompiler::Match::Builder->new
            ->starts_with( name => 'lineseq', skippable => true )
            ->followed_by( name => 'nextstate' )
            ->followed_by( name => 'entersub' )
            ->matches_on( name => 'pushmark',
                on_match => sub ($) {
                    $self->stream
                         ->take_until(sub ($op) { $op->name eq 'method_named' })
                         ->collect( Stream::Collectors->ToList )
                }
            )->build;
    }

    method parse {
        my ($filename, $version, @imports);

        INFO "** starting buffering" if DEBUG;
        $self->buffer->start_buffering;

        INFO "parsing ..." if DEBUG;
        INFO "parsing filename ..." if DEBUG;
        $filename = $self->stream->match($require);
        INFO "got ($filename) ..." if DEBUG;



        INFO "parsing method calls ..." if DEBUG;
        my @method_calls;
        while (my @method_call = $self->stream->match($method_call)) {
            if (scalar @method_call) {
                INFO "got method_call" if DEBUG;
                push @method_calls => \@method_call;
            }
            else {
                INFO "failed to match!!" if DEBUG;
                $self->set_error("Expected method call");
                return false;
            }
        }

        INFO "** stoping buffering" if DEBUG;
        $self->buffer->stop_buffering;

        INFO "got ".(scalar @method_calls)." method calls" if DEBUG;
        foreach my $method_call (@method_calls) {
            my $method_name = $method_call->[-1]->op->meth_sv->PV;
            INFO "checking method_call ($method_name) ..." if DEBUG;
            if ($method_name eq 'import') {
                INFO "got \&import" if DEBUG;
                if (scalar(@$method_call) > 2) {
                    @imports = map {
                        $_->op->sv->PV
                    } @{ $method_call }[1 .. ($#{$method_call} - 1) ];
                    INFO "got imports (".(join ', ' => @imports).")" if DEBUG;
                }
            }
            elsif  ($method_name eq 'VERSION') {
                INFO "got \&VERSION" if DEBUG;
                $version = $method_call->[-2]->op->sv->NV;
                INFO "got version ($version)" if DEBUG;
            }
            else {
                INFO "got \&HUH??? $method_name " if DEBUG;
                $self->set_error("Unexpected method ($method_name)");
                return false;
            }
        }

        INFO "got result!" if DEBUG;

        $self->set_result(ModuleImport->new(
            filename => $filename,
            version  => $version,
            imports  => \@imports
        ));

        INFO "got (".$self->result.")" if DEBUG;

        return $self->result // $self->error;
    }
}

my $parser = Deparser::ModuleImport->new(
    stream => Decompiler->new( from => \&Foo::Bar::foobar )->stream
);

my $result = $parser->parse;
isa_ok($result, 'ModuleImport');
is($result->filename, 'Foo.pm', '... got the expected filename');
is($result->version, '0.01', '... got the expected version');
eq_or_diff($result->imports, [qw[ bar baz ]], '... got the expected imports');
INFO $result if DEBUG;


done_testing;
