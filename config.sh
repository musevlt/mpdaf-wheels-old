# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    install_pkg_config
    build_simple cfitsio ${CFITSIO_VERSION:3370} https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    MPDAF_INSTALL_DIR=$(dirname $(python -c 'import mpdaf; print(mpdaf.__file__)'))
    echo $MPDAF_INSTALL_DIR
    python --version
    python -c "import mpdaf; print(mpdaf)"
    pwd
    ls
    pytest $MPDAF_INSTALL_DIR
}
