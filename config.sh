# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

CFITSIO_VERSION=${CFITSIO_VERSION:-3370}

function build_cfitsio {
    if [ -e cfitsio-stamp ]; then return; fi
    if [ -n "$IS_OSX" ]; then
        brew install cfitsio
    else
        # cannot use build_simple because cfitsio has no dash between name and version
        local cfitsio_name_ver=cfitsio${CFITSIO_VERSION}
        fetch_unpack https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/${cfitsio_name_ver}.tar.gz
        (cd cfitsio \
            && ./configure --prefix=$BUILD_PREFIX \
            && make shared && make install)
    fi
    touch cfitsio-stamp
}

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    build_cfitsio

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
    # Install cfitsio to run the combine tests
    source $MULTIBUILD_DIR/configure_build.sh
    source $MULTIBUILD_DIR/library_builders.sh
    build_curl
    build_cfitsio

    echo "backend : agg" > matplotlibrc

    # Runs tests on installed distribution from an empty directory
    MPDAF_INSTALL_DIR=$(dirname $(python -c 'import mpdaf; print(mpdaf.__file__)'))
    echo $MPDAF_INSTALL_DIR
    python --version
    pytest $MPDAF_INSTALL_DIR
}
