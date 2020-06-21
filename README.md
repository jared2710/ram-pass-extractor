# ram-pass-extractor
A command line tool for Linux built to extract leaked passwords out of memory images, after either unlocking a password-protected zip archive or after connecting to an FTP server using an FTP client.

Absolutely nothing needs to be installed for this to work, as it is a simple bash script and all commands used are built-in to Linux itself (such as strings, grep and echo).


## Why?

The use of encryption and passwords by suspects in a digital forensic investigation can severely limit the progress and eventual outcome of the investigation. Encryption and passwords are often used to hide the most incriminating evidence, and so if we could find these passwords for access or decryption, we may gain valuable evidence for the investigation. These passwords are almost never stored on the hard drive, and so the usual approach of making a forensically-sound copy of the hard drive and analyzing it is not sufficient.

However, after some in-depth experimentation, it was found that the passwords we desire may be leaked into RAM after execution of programs in which the passwords are entered. For example, it was found that if a **password-locked zip archive** had been unlocked recently (i.e. since the computer had been turned on), this password would still be present in RAM even after the unlocked files in the archive were closed. And after the use of a built-in **FTP client**, where passwords were entered to connect to a FTP server, these passwords were still present in RAM even after the FTP client was closed.

Therefore, before the DF investigator unplugs the computer, if they could do a quick RAM copy (using [dd](https://en.wikipedia.org/wiki/Dd_(Unix)) for example), and also note the filename of the locked zip archive (if that is the desired target), they could analyse that RAM image using this code, and hopefully extract the desired password from it.

## Video Demo
Head over to the following YouTube link to see the video demo of this code:

[COS 783 - Assignment 5](https://youtu.be/bHohC59NFlM)

## Installation

Installing this just involves cloning the git repo - nothing else is needed! 
```bash
git clone https://github.com/jared2710/ram-pass-extractor
cd ram-pass-extractor
```
The following built-in Linux commands are used by this bash script, just for reference (and in case your distro doesn't have them for some reason and you need to install them):
- bash
- echo, read, ls
- strings, cat, wc
- grep, head, awk
- if .. then ... elif ... then ... else ... fi
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

The above command will ask for the **filename of the memory image** (again, ensure they are in the same folder), and what type of password extraction you would like to perform, giving the following options:
- **zip**: Extract passwords recently used to unlock password-protected zip archives. You will be asked to provide the **filename of the zip archive** that you want to find the password for, which was located on the computer that the image was made from.
- **ftp**: Extract passwords recently used to connect to an FTP server using the built-in FTP client. No other information is needed for this.


The program will also check if the **strings have already been extracted** from the image, and prompt you regarding using the previously generated strings file, to save time.

Due to the almost random nature of RAM, it is difficult to identify a single password which is 'correct'. Therefore, a few options will be extracted and shown, and it is up to the analyst to see which one looks right (or just try them all when attempting to unlock the file - on a forensically sound copy of the suspect's hard drive, of course).

## Contribution
This code was coded entirely by Jared O'Reilly, a Computer Science Honours student at the University of Pretoria, in 2020. This was done for the COS 783 final assignment, involving main memory password forensics.
