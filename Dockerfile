FROM heroku/cedar:14

ENV CABAL_INSTALL cabal install --disable-documentation -j
ENV PATH /root/.cabal/bin:$PATH

# Install Haskell and Cabal
RUN apt-get update && \
    apt-get -y install haskell-platform wget libncurses5-dev && \
    apt-get clean
RUN cabal update && ${CABAL_INSTALL} cabal-install

RUN mkdir -p /app/bin
ENV PATH /app/bin:$PATH

# Elm 0.15, per http://elm-lang.org/Install.elm
# Modify this instruction for newer releases.
ENV ELM_VERSION 0.15
RUN mkdir /tmp/elm \
  && cd /tmp/elm \
  && cabal sandbox init \
  && ${CABAL_INSTALL} elm-compiler-0.15 elm-package-0.5 elm-make-0.1.2 \
  && ${CABAL_INSTALL} elm-repl-0.4.1 elm-reactor-0.3.1 \
  && cp .cabal-sandbox/bin/* /app/bin/

# Install spas
ENV SPAS_REPO "https://github.com/srid/spas.git "
RUN git clone ${SPAS_REPO} /tmp/spas
RUN cd /tmp/spas \
  && cabal update \
  && cabal sandbox init \
  && ${CABAL_INSTALL} \
  && cp .cabal-sandbox/bin/* /app/bin/


# Startup scripts for heroku
RUN mkdir -p /app/.profile.d /app/bin
RUN echo "export PATH=\"/app/bin:\$PATH\"" > /app/.profile.d/appbin.sh
RUN echo "cd /app" >> /app/.profile.d/appbin.sh

ENV PORT 3000
EXPOSE 3000


ENV LANG C.UTF-8
WORKDIR /app/src


ONBUILD ADD . /app/src
ONBUILD RUN rm -rf elm-stuff build && elm package install --yes
ONBUILD RUN make compile
# Install everything to /app
ONBUILD RUN cp -r build/* /app/
ONBUILD WORKDIR /app
ONBUILD RUN rm -rf /app/src
