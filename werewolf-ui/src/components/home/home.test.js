import React from 'react';
import { cleanup, render } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import { MemoryRouter } from 'react-router-dom'
import Home from './home';

describe('<home />', () => {
  afterEach(cleanup);

  test('it should mount', () => {
    const { getByTestId } = render(<Home />, { wrapper: MemoryRouter });
    const home = getByTestId('home');

    expect(home).toBeInTheDocument();
  });
});