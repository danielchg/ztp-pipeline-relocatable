import { getResource } from './resource-request';
import { Metadata } from './metadata';
import { IResource, IResourceDefinition } from './resource';

export type ServiceApiVersionType = 'v1';
export const ServiceApiVersion: ServiceApiVersionType = 'v1';

export type ServiceKindType = 'Service';
export const ServiceKind: ServiceKindType = 'Service';

export const SubscriptionDefinition: IResourceDefinition = {
  apiVersion: ServiceApiVersion,
  kind: ServiceKind,
};

export interface Service extends IResource {
  apiVersion: ServiceApiVersionType;
  kind: ServiceKindType;
  metadata: Metadata;
  spec?: {
    loadBalancerIP?: string;
    ports?: { name: string; protocol: string; port: number; targetPort: number }[];
    selector?: Record<string, string>;
    type?: string;
  };
  status?: {
    loadBalancer?: {
      ingress?: { ip?: string }[];
    };
  };
}

export const getService = (metadata: { name: string; namespace: string }) =>
  getResource<Service>({
    apiVersion: ServiceApiVersion,
    kind: ServiceKind,
    metadata,
  });
