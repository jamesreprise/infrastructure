# Primetime
Primetime is a content and media server. 

## bootstrap/
We bootstrap our server to life from the Hetzner 'rescue' system. Several things
are not ideal about this versus less opinionated bare metal (BIOS boot only,
custom zfs installation process). If you're not using Hetzner, this is unlikely
to be best practice or even very useful.

## config/
Some of the config for Primetime has been provided. I am in the process of 
learning to use Nix properly - it's unlikely to be of a very high quality.

### config/secrets/
We make use of [agenix](https://github.com/ryantm/agenix) for secret encryption.
