import type { LogMeta } from '../types/index.js';

interface LogEntry {
  level: string;
  message: string;
  timestamp: string;
  error?: string;
  stack?: string;
  [key: string]: unknown;
}

export const logger = {
  info: (message: string, meta: LogMeta = {}): void => {
    const entry: LogEntry = {
      level: 'info',
      message,
      timestamp: new Date().toISOString(),
      ...meta,
    };
    console.log(JSON.stringify(entry));
  },

  error: (message: string, error?: Error | unknown, meta: LogMeta = {}): void => {
    const err = error as Error | undefined;
    const entry: LogEntry = {
      level: 'error',
      message,
      error: err?.message ?? String(error),
      stack: err?.stack,
      timestamp: new Date().toISOString(),
      ...meta,
    };
    console.error(JSON.stringify(entry));
  },

  warn: (message: string, meta: LogMeta = {}): void => {
    const entry: LogEntry = {
      level: 'warn',
      message,
      timestamp: new Date().toISOString(),
      ...meta,
    };
    console.warn(JSON.stringify(entry));
  },

  debug: (message: string, meta: LogMeta = {}): void => {
    if (process.env.NODE_ENV !== 'production') {
      const entry: LogEntry = {
        level: 'debug',
        message,
        timestamp: new Date().toISOString(),
        ...meta,
      };
      console.log(JSON.stringify(entry));
    }
  },
};
