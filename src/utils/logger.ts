import type { LogMeta } from '../types/index.js';

interface LogEntry {
  level: string;
  message: string;
  timestamp: string;
  error?: string;
  stack?: string;
  [key: string]: unknown;
}

/**
 * Type-safe error message extraction
 * Handles unknown catch block errors properly
 */
export function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  if (typeof error === 'string') {
    return error;
  }
  return 'Unknown error';
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

  error: (message: string, error?: unknown, meta: LogMeta = {}): void => {
    const entry: LogEntry = {
      level: 'error',
      message,
      error: getErrorMessage(error),
      stack: error instanceof Error ? error.stack : undefined,
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
