<script lang="ts">
  import '../app.scss';
  import '../wasm_exec.js';
  import { assets } from '$app/paths';
  import { browser } from '$app/environment';
  import { loadSkillTree } from '../lib/skill_tree';
  import { syncWrap } from '../lib/worker';
  import { initializeCrystalline } from '../lib/types';

  const ui = {
    title: '\u6c38\u6052\u73e0\u5b9d\u8ba1\u7b97\u5668',
    loading: '\u52a0\u8f7d\u4e2d...'
  };

  let wasmLoading = true;

  // eslint-disable-next-line no-undef
  const go = new Go();

  if (browser) {
    fetch(assets + '/calculator.wasm')
      .then((data) => data.arrayBuffer())
      .then((data) => {
        WebAssembly.instantiate(data, go.importObject).then(async (result) => {
          go.run(result.instance);
          initializeCrystalline();
          await loadSkillTree(assets, true);
          wasmLoading = false;
        });

        syncWrap.boot(data);
      });
  }
</script>

{#if wasmLoading}
  <div class="flex flex-row justify-center h-screen">
    <div class="flex flex-col">
      <div class="py-10 flex flex-col justify-between">
        <div>
          <h1 class="text-white mb-10 text-center">{ui.title}</h1>

          <h2 class="text-center">{ui.loading}</h2>
        </div>
      </div>
    </div>
  </div>
{:else}
  <slot />
{/if}
