#!perl
use lib qw/lib/;
use Plack::Builder;
use Plack::App::Vim;

builder {
	enable "StackTrace";
    mount "/" => Plack::App::Vim->new(server => 'VIM');
};
