import { createBrowserRouter } from 'react-router';
import { StartPage } from '../features/request-form/StartPage';
import { Layout } from './Layout';
import { NotFoundPage } from './NotFoundPage';

export const router = createBrowserRouter([
  {
    element: <Layout />,
    children: [
      { path: '/', element: <StartPage /> },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
]);
