use rodio::{Decoder, DeviceSinkBuilder, Source};
use std::{fs::File, io::BufReader, path::PathBuf, sync::mpsc, thread};

pub struct TickPlayer {
    tx: mpsc::Sender<f32>,
}

impl TickPlayer {
    pub fn spawn(path: PathBuf) -> Self {
        let (tx, rx) = mpsc::channel::<f32>();

        thread::spawn(move || {
            let result = (|| -> anyhow::Result<()> {
                let mut sink = DeviceSinkBuilder::open_default_sink()?;
                sink.log_on_drop(false);

                // Decode once, keep the samples in memory
                let file = BufReader::new(File::open(&path)?);
                let tick = Decoder::try_from(file)?.buffered();

                // Blocks until a message arrives, stops when the sender is dropped
                for volume in rx {
                    sink.mixer().add(tick.clone().amplify(volume));
                }
                Ok(())
            })();

            if let Err(e) = result {
                eprintln!("Tick sound thread stopped: {e:#}");
            }
        });

        Self { tx }
    }

    pub fn play(&self, volume: f32) {
        // If the audio thread died, there is nothing useful to do here
        let _ = self.tx.send(volume);
    }
}

pub fn play_sound_file(resource_path: &str, volume: f32) -> Result<(), Box<dyn std::error::Error>> {
    // Get a output stream handle to the default physical sound device
    let mut stream_handle = DeviceSinkBuilder::open_default_sink()?;
    stream_handle.log_on_drop(false);
    let player = rodio::Player::connect_new(stream_handle.mixer());
    player.set_volume(volume);

    // Load a sound from a file, using a path relative to Cargo.toml
    let file = BufReader::new(File::open(resource_path)?);

    // Decode that sound file into a source
    let source = Decoder::try_from(file)?;
    player.append(source);
    player.sleep_until_end();
    Ok(())
}
