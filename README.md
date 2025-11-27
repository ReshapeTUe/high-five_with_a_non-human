# Imagining a high-five with a non-human: exploring soft haptic feedback at a science festival

(Anonymized) data and data processing and plotting code for the associated paper.

Paper link: (paper submitted, not yet published)


# Instructions
## dataset
Raw collected data are available as txt-files per participant, with filenames "pc#_pp#_date_time.txt", where:
- pc# corresponds to the computer number,
- pp# to the participant number.
- date = mm-dd-yyyy
- time = hh-mm

Each .txt contains space-separated data, starting with a header row:
"pp gender age time image pres freq area", where
- pp        = participant number
- gender    = gender (Male, Female, Other)
- age       = age (year)
- time      = time since application was started (s)
- image     = (see image name translations below)
- pres      = cue pressure (kPa)
- freq      = cue frequency (Hz)
- area      = cue size (small = centre ring only, medium = 2 rings, large = 3 rings)

image name translations:
```
Aap         monkey
Bmax        Baymax
Haai        shark
Hooiwagen   spider
Kat         Cat
Mieren      ants
Muis        mouse
Octopus     octopus
Olifant     elephant
Pepper      Pepper
Specht      woodpecker
WallE       WALL-E
Worm        worm
```

example data:
```
pp gender age time image pres freq area
6 Female 58 6583.52 Specht 25 20 medium 
6 Female 58 6597.57 Specht 30 20 medium 
6 Female 58 6607.78 Specht 30 20 large 
6 Female 58 6618.27 Specht 30 0 large 
6 Female 58 6629.26 Specht 30 30 small 
6 Female 58 6638.33 Muis 20 10 medium 
6 Female 58 6651.22 Aap 10 5 large 
6 Female 58 6657.83 Aap 10 30 large 
6 Female 58 6663.34 Aap 20 10 large 
...
```

## data processing and plotting:
Run matlab code:
- `First_prep_data.m` to parse raw data and save Matlab Table `Total` in `All_Data.mat`.
- `highfive_data_processing.m` to perform data analysis and recreate figures.

# Citing this work:
Please consider citing:

(paper submitted, not yet published)
