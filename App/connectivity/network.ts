import NetInfo from '@react-native-community/netinfo';
import { useEffect, useState } from 'react';

type ConnectivityListener = (isOnline: boolean) => void;

let isOnline = true;
const listeners = new Set<ConnectivityListener>();
let isInitialized = false;

function setOnline(nextValue: boolean) {
  if (isOnline === nextValue) {
    return;
  }
  isOnline = nextValue;
  listeners.forEach((listener) => {
    try {
      listener(isOnline);
    } catch (error) {
      console.error('Error in connectivity listener', error);
    }
  });
}

function initialize() {
  if (isInitialized) {
    return;
  }
  isInitialized = true;

  NetInfo.addEventListener((state) => {
    const online = Boolean(state.isConnected) && state.isInternetReachable !== false;
    setOnline(online);
  });

  NetInfo.fetch().then((state) => {
    const online = Boolean(state.isConnected) && state.isInternetReachable !== false;
    setOnline(online);
  });
}

export function getIsOnline() {
  initialize();
  return isOnline;
}

export function subscribeToConnectivity(listener: ConnectivityListener) {
  initialize();
  listeners.add(listener);
  listener(isOnline);
  return () => {
    listeners.delete(listener);
  };
}

export function useConnectivity() {
  const [online, setOnlineState] = useState(() => getIsOnline());

  useEffect(() => {
    return subscribeToConnectivity(setOnlineState);
  }, []);

  return online;
}


