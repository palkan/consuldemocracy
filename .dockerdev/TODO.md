# Docker Dev Environment: Next Steps

These steps are optional. The base setup works without them.

## Verify the setup

The setup was not run during generation. Run these commands to check it:

```sh
dip provision
dip rspec
dip lint
```

## Optional improvements

- **Precompile test assets.** CI runs `rake assets:precompile` before the tests.
  Without it, Sprockets compiles assets on the first request and slow system tests can time out.
  Run `dip RAILS_ENV=test rails assets:precompile` if this happens.
  The `assets` volume keeps `public/assets`; run `dip rails assets:clobber` before you work in development.
- **Run tests in parallel.** CI uses Knapsack Pro (`bin/knapsack_pro_rspec`).
  Locally, you can add a `parallel_tests` setup or run spec folders in separate `dip rspec` calls.
- **Watch system tests in a browser.** Chromium runs headless in the Rails container.
  To see the browser, add a separate Chrome service with VNC (see [System of a test](https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing#dockerizing-system-tests)).
- **Add background jobs.** Production uses Delayed Job. Add a `worker` service with `bundle exec rake jobs:work` if you need it in development.
- **Add memcached.** Production uses `:mem_cache_store`. Development uses `:memory_store`, so memcached is not required.
- **Use the dev image in CI.** You can run the CI workflows with `.dockerdev/compose.yml` to get the same environment.
- **Vite.** The app uses Sprockets now. If you move to Vite, add a `vite` service (see [Vite-lizing Rails](https://evilmartians.com/chronicles/vite-lizing-rails-get-live-reload-and-hot-replacement-with-vite-ruby#dockerizing-vite-or-not)).
- **Remove the old Docker setup.** The root `Dockerfile` and `docker-compose.yml` are a separate setup. Keep them in sync with `.dockerdev/` or remove one of them.
