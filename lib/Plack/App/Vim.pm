package Plack::App::Vim;
use strict;
use warnings;
use parent qw/Plack::Component/;
use Plack::Request;
use Encode;
use JSON::PP;

sub prepare_app {
    my $self = shift;
    $self->{vim} ||= 'vim';
    if (!$self->{server}) {
        open(my $f, "vim --serverlist|");
        my $server = <$f>;
        close($f);
        chomp $server;
        $self->{server} = $server;
    }
    if (!$self->{encoding}) {
        open(my $f, sprintf("%s --servername %s --remote-expr \"&encoding\"|",
            $self->{vim}, $self->{server}));
        my $encoding = <$f>;
        close($f);
        chomp $encoding;
        $self->{encoding} = $encoding;
    }
    $self;
}

sub call {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);
    my $json = JSON::PP->new->ascii
        ->allow_singlequote->allow_blessed->allow_nonref;
    my $str = $json->encode({
        uri => $env->{PATH_INFO}||'',
        method => $req->method,
        headers => [split( /\n/, $req->headers->as_string)],
        content => $req->content,
    });
    $str =~ s!"!\\x22!g;

    my $command;
    if ($^O eq 'MSWin32') {
        $command = sprintf(
            '%s --servername %s --remote-expr "vimplack#handle("""%s""")"',
            $self->{vim}, $self->{server},
            encode($self->{encoding} || 'utf8', $str));
    } else {
        $command = sprintf(
            "%s --servername %s --remote-expr 'vimplack#handle(\"%s\")'",
            $self->{vim}, $self->{server},
            encode($self->{encoding} || 'utf8', $str));
    }
    open(my $f, "$command|");
    binmode $f, ':utf8';
    my $out = <$f>;
    close $f;
    my $res = $json->decode($out);
    $res->[2][0] = encode_utf8 $res->[2][0] if $res;
    $res || [500, ['Content-Type' => 'text/plain'], ['Internal Server Error']];
}

1;

__END__

=head1 NAME

Plack::App::Vim - The Vim App in Plack

=head1 SYNOPSIS

  use Plack::Builder;
  use Plack::App::Vim;

  builder {
    mount "/" => Plack::App::Vim->new(server => 'VIM');
  };

=head1 DESCRIPTION

Plack::App::Vim allows you to write web application with Vim script.

=head1 AUTHOR

Yasuhiro Matsumoto

=head1 SEE ALSO

L<Plack>

=cut
