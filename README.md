# pyth-ffi

Gets and/or updates pyth prices within forge scripts using ffi.

## Requirements

**foundry**

```shell
curl -L https://foundry.paradigm.xyz | bash
```

**bun**

```shell
curl -fsSL https://bun.sh/install | bash
```

## Usage

1. `bun install`

2. Set your hermes endpoint(s) in: ts/config.ts. If the request fails it will iterate to the next one.

3. See `scripts/ExampleScript.s.sol` or `test/Pyth.t.sol` for examples.
