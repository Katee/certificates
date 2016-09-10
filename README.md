Certificates generation and mailer [![Build Status](https://snap-ci.com/agile-alliance-brazil/certificates/branch/master/build_image)](https://snap-ci.com/agile-alliance-brazil/certificates/branch/master) [![Dependency Status](https://gemnasium.com/agile-alliance-brazil/certificates.svg)](https://gemnasium.com/agile-alliance-brazil/certificates) [![Code Climate](https://codeclimate.com/github/agile-alliance-brazil/certificates/badges/gpa.svg)](https://codeclimate.com/github/agile-alliance-brazil/certificates) [![Test Coverage](https://codeclimate.com/github/agile-alliance-brazil/certificates/badges/coverage.svg)](https://codeclimate.com/github/agile-alliance-brazil/certificates)
==================================

This is a small helper script to generate and send attendees a certificate PDF based on an SVG, a CSV and an email template.

Prerequisite
============

In order to run this script you need [ruby 2.3.1](http://www.ruby-lang.org/).

How to Use
==========

Download the [project's ZIP](https://github.com/agile-alliance-brazil/certificates/archive/master.zip) or clone the project somewhere:

```
git clone https://github.com/agile-alliance-brazil/certificates.git
```

In the root folder, run:

```
./setup.sh
```

This will create a .env file in that same folder. Open it and edit the values to match your needs. Copy the example folder into your own (let's say "data"), change the contents to match your attendees (in a CSV file called data.csv inside that folder), your certificate's svg (called model.svg in that folder) and an email template in markdown (called email.md.erb). Then run:

```
bundle exec ruby ./lib/generate_certificates.rb data --dry-run
```

This should generate the certificates for you and just print what action would be taken (not actually sending the emails). It'll cache the generated certificate PDFs in a folder called certificates in your current directory. Check the '--cache' option for details on that.

You can also provide a --prefix option with a prefix text for every PDF's file name if that helps you.

Once you're happy with the results, just run the same thing without the '--dry-run' option.

PDF Convertion
==============

If you want to use [Inkscape](http://www.inkscape.org) to generate your PDFs, ensure you have either INKSCAPE_PATH in your .env file or defined as an environment variable. Otherwise, we will use [prawn-svg](https://github.com/mogest/prawn-svg) to convert from SVG to PDF which may have different results than Inkscape (notably, won't convert flowRoot elements, those have to be transformed into text elements and won't have access to unix/X11 fonts).

Development
===========

You can start guard with ``./dev.sh`` or just run all tests with ``./setup.sh && bundle exec rake``.
