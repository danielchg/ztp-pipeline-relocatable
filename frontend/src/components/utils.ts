import { K8SStateContextData } from './K8SStateContext';
import { IpTripletSelectorValidationType } from './types';

const DNS_NAME_REGEX = /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/;

// keep following in sync with the backend
const USERNAME_REGEX = /^[a-z]([-a-z0-9]*[a-z0-9])?$/;

export const addIpDots = (addressWithoutDots: string): string => {
  if (addressWithoutDots?.length === 12) {
    let address = addressWithoutDots.substring(0, 3) + '.';
    address += addressWithoutDots.substring(3, 6) + '.';
    address += addressWithoutDots.substring(6, 9) + '.';
    address += addressWithoutDots.substring(9);

    return address;
  }

  throw Error('Invalid address: ' + addressWithoutDots);
};

export const ipTripletAddressValidator = (addr: string): IpTripletSelectorValidationType => {
  const validation: IpTripletSelectorValidationType = { valid: true, triplets: [] };

  for (let i = 0; i <= 3; i++) {
    const triplet = addr.substring(i * 3, (i + 1) * 3).trim();
    const num = parseInt(triplet);
    const valid = num > 0 && num < 256;

    validation.valid = validation.valid && valid;
    validation.triplets.push(valid ? 'success' : 'default');
  }

  if (!validation.valid) {
    validation.message = 'Provided IP address is incorrect.';
  }
  return validation;
};

export const domainValidator = (domain: string): K8SStateContextData['domainValidation'] => {
  if (!domain || domain?.match(DNS_NAME_REGEX)) {
    return ''; // passed ; optional - pass for empty as well
  }
  return "Valid domain wasn't provided";
};

export const usernameValidator = (username = ''): K8SStateContextData['username'] => {
  if (username.length >= 54) {
    return 'Valid username can not be longer than 54 characters.';
  }

  if (!username || username.match(USERNAME_REGEX)) {
    return ''; // passed
  }

  return "Valid username wasn't provided";
};

export const passwordValidator = (pwd = ''): K8SStateContextData['password'] => {
  // We are validating password in PasswordRequirements component
  return ''; // passed
};

export const ipWithDots = (ip: string): string =>
  (
    ip.substring(0, 3) +
    '.' +
    ip.substring(3, 6) +
    '.' +
    ip.substring(6, 9) +
    '.' +
    ip.substring(9, 12)
  ).replaceAll(' ', '');

export const ipWithoutDots = (ip?: string): string => {
  if (ip) {
    const triplets = ip.split('.');
    if (triplets.length === 4) {
      let result = triplets[0].padStart(3, ' ');
      result += triplets[1].padStart(3, ' ');
      result += triplets[2].padStart(3, ' ');
      result += triplets[3].padStart(3, ' ');
      return result;
    }
  }

  console.info('Unrecognized ip address format "', ip, '"');
  return '            '; // 12 characters
};