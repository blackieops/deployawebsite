FROM ruby:2.6.3
ADD . /usr/src/site
WORKDIR /usr/src/site
RUN bundle install --deployment
RUN make

FROM nginx:1.17.0-alpine
COPY --from=0 /usr/src/site/dist/ /usr/share/nginx/html/
RUN chown -R nginx:nginx /usr/share/nginx/html
