package MeCab::IJDetector;

use strict;
use warnings;
use utf8;
use Encode 'decode_utf8';
use Text::Shirasu;
use YAML::Tiny;
use Pry;

my $inside_jokes = YAML::Tiny->read('./inside_jokes.yml')->[0];

sub search {
  my ($pkg, $input) = @_;
  my $ts = Text::Shirasu->new(dicdir => '/usr/local/lib/mecab/dic/mecab-ipadic-neologd');
  my $included_jokes = [];

  # 空白及び改行除去
  $input =~ s/\n|\t| |　//g;

  # 内輪ネタ検索
  $ts->parse($input);
  for my $inside_joke (@$inside_jokes) {
    my $map = "@{[$inside_joke->{joke}]} => @{[$inside_joke->{mean}]}";
    
    push(@$included_jokes, $map) and next
      if grep { $inside_joke->{joke} eq decode_utf8($_->surface) } @{$ts->nodes};
    push(@$included_jokes, $map)
      if $inside_joke->{consolidation} and $input =~ $inside_joke->{joke};
  }

  return $included_jokes;
}

1;