# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    # build_simple cfitsio ${CFITSIO_VERSION:-3370} https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio
    if [ -n "$IS_OSX" ]; then
        brew install cfitsio
    else
        local cfitsio_name_ver=cfitsio${CFITSIO_VERSION:-3370}
        fetch_unpack https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/${cfitsio_name_ver}.tar.gz
        (cd cfitsio \
            && ./configure --prefix=$BUILD_PREFIX \
            && make shared && make install)
    fi

    if [ -n "$IS_OSX" ]; then
        install_pkg_config
    fi

    # Use c99 for NAN
    export CFLAGS="-std=c99"
}

function pip_opts {
    # Extra options for pip
    if [ -n "$IS_OSX" ]; then
        local suffix=scipy_installers
    else
        local suffix=manylinux
    fi
    echo "-v --only-binary matplotlib --find-links https://nipy.bic.berkeley.edu/$suffix"
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    echo "backend : agg" > matplotlibrc
    MPDAF_INSTALL_DIR=$(dirname $(python -c 'import mpdaf; print(mpdaf.__file__)'))
    echo $MPDAF_INSTALL_DIR
    python --version
    pytest $MPDAF_INSTALL_DIR
}
