<script lang="ts">
  import Select from 'svelte-select';
  import { browser } from '$app/environment';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { base, assets } from '$app/paths';
  import { calculator, data } from '../lib/types';
  import { translateAlternatePassiveName, translatePassiveNodeName, translateStat } from '../lib/skill_tree';
  import { selectPlaceholder, translateConqueror, translateTimelessJewel } from '../lib/locale';

  const ui = {
    title: '\u6c38\u6052\u73e0\u5b9d\u8ba1\u7b97\u5668',
    treeView: '\u5929\u8d4b\u6811\u89c6\u56fe',
    timelessJewel: '\u6c38\u6052\u73e0\u5b9d',
    conqueror: '\u5f81\u670d\u8005',
    passiveSkill: '\u5929\u8d4b\u70b9',
    seed: '\u79cd\u5b50',
    seedRangePrefix: '\u79cd\u5b50\u8303\u56f4\u5fc5\u987b\u5728',
    seedRangeLink: '\u5230',
    alternatePassiveSkill: '\u66ff\u4ee3\u5929\u8d4b\u8bcd\u6761',
    additions: '\u9644\u52a0\u8bcd\u6761',
    noName: '\u65e0\u540d\u79f0',
    source: '\u6e90\u7801\uff08\u0047\u0069\u0074\u0048\u0075\u0062\uff09',
    selectPlaceholder
  };

  const searchParams = $page.url.searchParams;

  const jewels = Object.keys(data.TimelessJewels).map((k) => ({
    value: parseInt(k),
    label: translateTimelessJewel(data.TimelessJewels[k]),
    rawLabel: data.TimelessJewels[k]
  }));

  let selectedJewel = searchParams.has('jewel') ? jewels.find((j) => j.value == searchParams.get('jewel')) : undefined;

  $: conquerors = selectedJewel
    ? Object.keys(data.TimelessJewelConquerors[selectedJewel.value]).map((k) => ({
        value: k,
        label: translateConqueror(k),
        rawLabel: k
      }))
    : [];

  const conquerorValue = searchParams.get('conqueror') || '';
  let selectedConqueror = searchParams.has('conqueror')
    ? {
        value: conquerorValue,
        label: translateConqueror(conquerorValue),
        rawLabel: conquerorValue
      }
    : undefined;

  const passiveSkills = Object.values(data.PassiveSkills).map((passive) => ({
    value: passive.Index,
    label: translatePassiveNodeName(passive.PassiveSkillGraphID, passive.Name) + ' (' + passive.ID + ')'
  }));

  let selectedPassiveSkill: { label: string; value: number } = searchParams.has('passive_skill')
    ? passiveSkills.find((j) => j.value == searchParams.get('passive_skill'))
    : undefined;

  let seed = searchParams.has('seed') ? searchParams.get('seed') : 0;

  let result: undefined | data.AlternatePassiveSkillInformation;

  $: {
    if (selectedPassiveSkill && seed && selectedJewel && selectedConqueror) {
      result = calculator.Calculate(
        selectedPassiveSkill.value,
        typeof seed === 'string' ? parseInt(seed) : seed,
        selectedJewel.value,
        selectedConqueror.value
      );
    }
  }

  const updateUrl = () => {
    if (browser) {
      const params: object = {};
      selectedJewel && (params.jewel = selectedJewel.value);
      selectedConqueror && (params.conqueror = selectedConqueror.value);
      selectedPassiveSkill && (params.passive_skill = selectedPassiveSkill.value);
      seed && (params.seed = seed);

      const resultQuery = Object.keys(params)
        .map((key) => key + '=' + encodeURIComponent(params[key]))
        .join('&');

      goto($page.url.pathname + '?' + resultQuery);
    }
  };
</script>

<div class="py-10 flex flex-row justify-center w-screen h-screen">
  <div class="flex flex-col justify-between w-1/3">
    <div>
      <h1 class="text-white mb-10 text-center">{ui.title}</h1>

      <a href="{base}/tree">
        <h2 class="text-white mb-10 text-center underline text-orange-500">{ui.treeView}</h2>
      </a>

      <div class="themed">
        <h3 class="mb-2">{ui.timelessJewel}</h3>
        <Select items={jewels} bind:value={selectedJewel} on:select={updateUrl} placeholder={ui.selectPlaceholder} />

        {#if selectedJewel}
          <div class="mt-4">
            <h3 class="mb-2">{ui.conqueror}</h3>
            <Select
              items={conquerors}
              bind:value={selectedConqueror}
              on:select={updateUrl}
              placeholder={ui.selectPlaceholder} />
          </div>

          {#if selectedConqueror && Object.keys(data.TimelessJewelConquerors[selectedJewel.value]).indexOf(selectedConqueror.value) >= 0}
            <div class="mt-4">
              <h3 class="mb-2">{ui.passiveSkill}</h3>
              <Select
                items={passiveSkills}
                bind:value={selectedPassiveSkill}
                on:select={updateUrl}
                placeholder={ui.selectPlaceholder} />
            </div>

            {#if selectedPassiveSkill}
              <div class="mt-4">
                <h3 class="mb-2">{ui.seed}</h3>
                <input
                  type="number"
                  bind:value={seed}
                  class="seed"
                  on:blur={updateUrl}
                  min={data.TimelessJewelSeedRanges[selectedJewel.value].Min}
                  max={data.TimelessJewelSeedRanges[selectedJewel.value].Max} />
                {#if seed < data.TimelessJewelSeedRanges[selectedJewel.value].Min || seed > data.TimelessJewelSeedRanges[selectedJewel.value].Max}
                  <div class="mt-2">
                    {ui.seedRangePrefix} {data.TimelessJewelSeedRanges[selectedJewel.value].Min} {ui.seedRangeLink} {data
                      .TimelessJewelSeedRanges[selectedJewel.value].Max}
                  </div>
                {/if}
              </div>

              {#if result}
                {#if result.AlternatePassiveSkill}
                  <div class="mt-4">
                    <h3>{ui.alternatePassiveSkill}</h3>
                    <span
                      >{translateAlternatePassiveName(result.AlternatePassiveSkill.StatsKeys, result.AlternatePassiveSkill.Name)} ({result.AlternatePassiveSkill.ID}) ({result.AlternatePassiveSkill})</span>
                  </div>

                  {#if result.StatRolls && Object.keys(result.StatRolls).length > 0}
                    <ol class="mt-4 list-decimal pl-8">
                      {#each Object.keys(result.StatRolls) as roll, i}
                        {@const statId = result.AlternatePassiveSkill.StatsKeys[i]}
                        {@const stat = data.GetStatByIndex(statId)}
                        <li>{translateStat(statId, result.StatRolls[roll])} ({stat?.ID || ui.noName})</li>
                      {/each}
                    </ol>
                  {/if}
                {/if}

                {#if 'AlternatePassiveAdditionInformations' in result && result.AlternatePassiveAdditionInformations?.length > 0}
                  <div class="mt-4">
                    <h3>{ui.additions}</h3>
                    <ul class="list-disc pl-8">
                      {#each result.AlternatePassiveAdditionInformations as info}
                        <li class="mt-4">
                          <span>{info.AlternatePassiveAddition.ID} ({info.AlternatePassiveAddition.Index})</span>

                          {#if info.StatRolls && Object.keys(info.StatRolls).length > 0}
                            <ol class="list-decimal pl-8">
                              {#each Object.keys(info.StatRolls) as roll, i}
                                {@const statId = info.AlternatePassiveAddition.StatsKeys[i]}
                                {@const stat = data.GetStatByIndex(statId)}
                                <li>{translateStat(statId, info.StatRolls[roll])} ({stat?.ID || ui.noName})</li>
                              {/each}
                            </ol>
                          {/if}
                        </li>
                      {/each}
                    </ul>
                  </div>
                {/if}
              {/if}
            {/if}
          {/if}
        {/if}
      </div>
    </div>

    <div class="flex justify-between">
      <div class="text-right text-orange-500">
        <a href="https://discord.gg/mfacademy" target="_blank" rel="noopener" class="flex flex-row align-middle">
          <img src="{assets}/mf-academy-logo.png" width="24px" />
          <span class="ml-2">MF Academy</span>
        </a>
      </div>

      <div class="text-orange-500">
        <a href="https://github.com/Vilsol/timeless-jewels" target="_blank" rel="noopener">{ui.source}</a>
      </div>
    </div>
  </div>
</div>
