# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        install_pkg_config
    fi
    # build_simple cfitsio ${CFITSIO_VERSION:-3370} https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio
    local cfitsio_name_ver=cfitsio${CFITSIO_VERSION:-3370}
    fetch_unpack https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/${cfitsio_name_ver}.tar.gz
    (cd cfitsio \
        && ./configure --prefix=$BUILD_PREFIX \
        && make && make install)

    build_openblas

    local sex_name_ver=sextractor-${SEX_VERSION:-2.19.5}
    fetch_unpack https://www.astromatic.net/download/sextractor/${sex_name_ver}.tar.gz
    (cd $sex_name_ver \
        && ./configure --prefix=$BUILD_PREFIX \
        && make && make install)
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
