#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]
use clap::Parser;

use clap::Subcommand;

#[derive(Parser)]
#[command(version, about, long_about = None)]
#[command(propagate_version = true)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Run the CLI version of the app
    Cli,
}

// Kept from the Pomodorolm era: changing it would make existing users
// lose their config (it lives in e.g. `~/.config/pomodorolm/`).
const CONFIG_DIR_NAME: &str = "pomodorolm";

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    // You can check for the existence of subcommands, and if found use their
    // matches just as you would the top level cmd
    match &cli.command {
        Some(command) => match command {
            Commands::Cli => concentre_lib::cli::run(CONFIG_DIR_NAME),
        },
        None => {
            concentre_lib::run_gui(CONFIG_DIR_NAME);
            Ok(())
        }
    }
}
