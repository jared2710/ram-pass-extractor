# ram-pass-extractor
A command line tool for Linux built to extract passwords out of memory images for password-archived files.

Absolutely nothing needs to be installed for this to work, as it is a simple bash script and all commands used are built-in to Linux itself (such as strings, grep and echo).


## Why?

If a suspect stores their incriminating data in a password-locked zip archive, it is basically impossible for a digital forensic investigator to obtain the contents of that incriminating data once getting a hold of that computer.

However, after in-depth experimentation, it was revealed that if the password-locked zip archive had been unlocked recently (i.e. since the computer had been turned on), this password would still be present in RAM even after the unlocked files in the archive were closed.

Therefore, before the DF investigator unplugs the computer, if they could do a quick RAM copy (using [dd](https://en.wikipedia.org/wiki/Dd_(Unix)) for example), and note the filename of the zip archive (e.g. message.zip), they could analyse that RAM image using this code, and hopefully extract the desired password from it - which could prove extremely useful for further investigation.

## Installation

Installing this just involves cloning the git repo - nothing else is needed! 
```bash
git clone https://github.com/jared2710/zip-pass-extractor
cd zip-pass-extractor
```
The following built-in Linux commands are used by this bash script, just for reference (and in case your distro doesn't have them for some reason and you need to install them):
- bash
- echo, read, ls
- strings, cat, wc
- grep, head, awk
- if .. then ... else ... fi
- for ... do ... done
- eval


## Usage

To analyse a memory image, make sure the memory image is in the same folder as extract.sh (the bash script). 

Memory images used to test this code were made from a Windows XP SP3 virtual machine, and the following dd command was used to make these RAM images:
```bash
dd if=\\.\PhysicalMemory of=memory.img bs=4096 --md5sum --verifymd5 --md5out=memory.md5
```

Then, simply run the command below, and follow the prompts as requested to extract passwords out of the RAM image:
```bash
bash extract.sh
```

The above command will ask for the **filename of the memory image** (again, ensure they are in the same folder) as well as the **filename of the zip archive** that we want to find the password for, which was located on the computer that the image was made from. It will also check if the **strings have already been extracted** from the image, and prompt you regarding using the previously generated strings file, to save time.

Due to the almost random nature of RAM, it is difficult to identify the exact password. Therefore, a few options will be extracted and shown, and it is up to the analyst to see which one looks right (or just try them all when attempting to unlock the file - on a forensically sound copy of the suspect's hard drive, of course).

## Contribution
This code was coded entirely by Jared O'Reilly, a Computer Science Honours student at the University of Pretoria, in 2020. This was done for the COS 783 final assignment, involving main memory password forensics.
