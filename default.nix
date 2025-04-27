{ rustPlatform,
  fetchFromGitHub,
  openssl,
  dbus,
  pkg-config }:
rustPlatform.buildRustPackage rec {
  pname = "mpris-discord-rpc";
  version = "v0.4.0";
  
  src = fetchFromGitHub {
    owner = "patryk-ku";
    repo = pname;
    rev = version;
    hash = "sha256-szftij29YTLzqBNirvoTgZfPIRznM1Ax5MPTKqB1nYI=";
  };

  postPatch = ''
    echo "LASTFM_API_KEY=9ee4c0cf26335be5b1259ed067e28fc3" > .env
  '';

  cargoHash = "sha256-8bJ6esBiA1fkwiqhNBPQIvkPI2RgHXJrlFxe2EyCdOA=";
  buildInputs = [ openssl dbus ];
  nativeBuildInputs = [ pkg-config ];
}
