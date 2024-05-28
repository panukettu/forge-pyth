import type { Hex } from 'viem'
import { tickers } from './config'

export function isPythTicker(asset: string): asset is Pyth.Ticker {
  return Object.keys(tickers).includes(asset)
}
export function isPythID(str: string): str is Pyth.ID {
  return str.startsWith('0x') && str.length === 66
}

export function formatPrice(price: Pyth.Price) {
  return {
    price: BigInt(price.price),
    conf: BigInt(price.conf),
    expo: price.expo,
    publishTime: BigInt(price.publish_time),
  }
}

export declare namespace Pyth {
  export type ID = Hex
  export type Ticker = keyof typeof tickers
  export type Price = {
    price: string
    conf: string
    expo: number
    publish_time: number
  }

  type Metadata = {
    slot: number
    emitter_chain: number
    price_service_receive_time: number
    prev_publish_time: number
  }

  export type V2Response = {
    binary: {
      encoding: string
      data: string[]
    }
    parsed: {
      id: string
      price: Price
      ema_price: Price
      metadata: Metadata
    }[]
  }
}
