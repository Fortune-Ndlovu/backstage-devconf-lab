import { createBackendPlugin, coreServices } from '@backstage/backend-plugin-api';
import { createApiRoutes } from '@roadiehq/rag-ai-backend';
import { Ollama } from '@langchain/community/llms/ollama';
import type { Router as ExpressRouter } from 'express';
import { EmbeddingDoc } from '@roadiehq/rag-ai-node';

const dummyAugmentationIndexer = {
  vectorStore: {
    addDocuments: async () => {},
    similaritySearch: async () => [],
    connectEmbeddings: async () => {},
    deleteDocuments: async () => {},
  },
  index: async () => {},
  createEmbeddings: async () => 0,
  deleteDocuments: async () => {},
  deleteEmbeddings: async () => {},
  connectEmbeddings: async () => {},
};

const dummyRetrievalPipeline = {
  retrieveRelevantDocuments: async (): Promise<EmbeddingDoc[]> => [],
  retrieveAugmentationContext: async (): Promise<EmbeddingDoc[]> => [],
};

const aiPlugin = createBackendPlugin({
  pluginId: 'rag-ai',
  register(env) {
    env.registerInit({
      deps: {
        logger: coreServices.logger,
        config: coreServices.rootConfig,
        discovery: coreServices.discovery,
        httpRouter: coreServices.httpRouter,
      },
      async init({ logger, config, httpRouter }) {
        const model = new Ollama({
          baseUrl: 'http://localhost:11434',
          model: 'llama3',
          temperature: 0.7,
        });

        const ragAi = await createApiRoutes({
          logger,
          config,
          model,
          augmentationIndexer: dummyAugmentationIndexer,
          retrievalPipeline: dummyRetrievalPipeline,
        });

        httpRouter.use(ragAi.router as unknown as ExpressRouter);
      },
    });
  },
});

export default aiPlugin;
