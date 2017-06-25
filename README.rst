docker-kaldi-android
####################

Dockerfile for compiling Kaldi for Android. Based on instructions published at
http://jcsilva.github.io/2017/03/18/compile-kaldi-android/.


Install docker
==============

Please, refer to https://docs.docker.com/engine/installation/.


Build the image
===============

* Build your own image (requires git):

.. code-block:: bash

  $ git clone https://github.com/jcsilva/docker-kaldi-android
  $ cd docker-kaldi-android
  $ docker build -t kaldi-android-base:latest .


How to use
==========

First of all, clone Kaldi repository to somewhere in your machine.

.. code-block:: bash

  $ git clone https://github.com/kaldi-asr/kaldi


Run a container, mounting the Kaldi repository you just cloned to /opt/kaldi:

.. code-block:: bash

  $ docker run -v /home/test/kaldi:/opt/kaldi kaldi-android-base:latest

In the above example, it was assumed the Kaldi repository was cloned to
``/home/test/kaldi``. If you cloned it to somewhere else, you must change it
accordingly.

When ``docker run`` finishes, all the compiled Android binaries will be located
in ``/home/test/kaldi/src`` subdirectories.
