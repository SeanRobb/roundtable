import React from 'react';
import { cleanup, render } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import Register from './register';

describe('<register />', () => {
  afterEach(cleanup);

  test('it should mount', () => {
    const { getByTestId } = render(<Register />);
    const register = getByTestId('register');

    expect(register).toBeInTheDocument();
  });
});