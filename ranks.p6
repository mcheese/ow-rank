use HTTP::UserAgent;

sub get-ow {
  my $r = HTTP::UserAgent.new.get("http://masteroverwatch.com/leaderboards/pc/global");
  die unless $r.is-success;
  $r.content ~~ /\[\W*count[\W*\,\W*(\d+)]*/;
  my @amount = map *.Int, $0;
  my $total = @amount.sum;
  my $p = 0;
  gather for @amount {
    take $p / $total;
    $p += $_;
  }
}

sub get-lol {
  my $r = HTTP::UserAgent.new.get("http://www.leagueofgraphs.com/rankings/rank-distribution");
  die unless $r.is-success;
  $r.content ~~ / "Soloqueue" [ .*? "title=\"" (.*?) \" .*? "<i>" (.*?) "</i>"]* /;
  my @leagues = map *.Str, $0;
  my @amount = map *.chop.Num, $1;
  my $total = @amount.sum;
  my $p = 0;
  gather for reverse (0 ..^ @leagues.elems) {
    take @leagues[$_] => $p / $total;
    $p += @amount[$_];
  }
}

sub get-csgo {
  my $r = HTTP::UserAgent.new.get("https://csgosquad.com/ranks");
  die unless $r.is-success;
  $r.content ~~ / \"weeks\"\:\[\{\"distribution\"\:\[ [(.*?) <[\,\]]>]**18  /;
  my @amount = map *.Num, $0;
  my @leagues = "Silver I", "Silver II", "Silver III", "Silver IV", "Silver Elite",
                "Silver Elite Master", "Gold Nova I", "Gold Nova II", "Gold Nova III",
                "Gold Nova Master", "Master Guardian I", "Master Guardian II",
                "Master Guardian Elite", "Distringuished Master Guardian", "Legendary Eagle",
                "Legendary Eagle Master", "Supreme Master First Class", "The Global Elite";
  my $total = @amount.sum;
  my $p = 0;
  gather for (0 ..^ @leagues.elems) {
    take @leagues[$_] => $p / $total;
    $p += @amount[$_];
  }
}

my @ow = get-ow;
my @lol = get-lol;
my @go = get-csgo;
my $l = 0;
my $g = 0;
say "| OW Rank | Distribution | LoL Rank | CSGO Rank |";
say "| :------ | :----------- | :------- | :-------- |";
for @ow {
  $l++ while $l < @lol.elems - 1 and @lol[$l + 1].value < $_;
  $g++ while $g < @go.elems - 1 and @go[$g + 1].value < $_;
  say "| {++$} | {$_} | {@lol[$l].key} | {@go[$g].key} |";
}

