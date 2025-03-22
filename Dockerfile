FROM debian:bookworm as builder

RUN apt-get update && apt-get install --no-install-recommends -y clang llvm libx11-dev libxss-dev libxrandr-dev pkg-config haskell-stack

COPY stack.yaml /mnt
COPY *.cabal /mnt
WORKDIR /mnt
RUN rm -rf ~/.stack &&  \
    stack upgrade && \
    stack config set system-ghc --global true && \
    stack install --ghc-options="-fPIC" --only-dependencies

COPY . /mnt

# Hack as no Xss static lib on alpine, we don't need it
RUN echo '  ld-options: -static -Wl,--unresolved-symbols=ignore-all' >> greenclip.cabal ; \
    stack install  --ghc-options="-fPIC"
#RUN upx --ultra-brute /root/.local/bin/greenclip



FROM debian:bookworm as runner

WORKDIR /root
COPY --from=builder /root/.local/bin/greenclip .
RUN chmod +x ./greenclip

CMD ["./greenclip"]

